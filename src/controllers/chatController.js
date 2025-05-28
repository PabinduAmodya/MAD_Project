import { db } from '../firebase.js';
import { v4 as uuidv4 } from 'uuid';

// Start a chat (Check if chat exists, otherwise create)
export const startChat = async (req, res) => {
    try {
        const { workerId } = req.body;
        const userId = req.user.id; // Get user ID from token
        
        // Validate workerId
        if (!workerId) {
            return res.status(400).json({ error: 'Worker ID is required' });
        }
        
        // Check if worker exists in users collection
        const workerDoc = await db.collection('users').doc(workerId).get();
        if (!workerDoc.exists || workerDoc.data().role !== 'worker') {
            console.log('Worker not found:', {
                workerId,
                exists: workerDoc.exists,
                role: workerDoc.exists ? workerDoc.data().role : 'N/A'
            });
            return res.status(404).json({ error: 'Worker not found' });
        }
        
        // Check if a chat already exists
        const chatQuery = await db.collection('chats')
            .where('users', 'array-contains', userId)
            .get();
            
        let chatId = null;
        chatQuery.forEach(doc => {
            const data = doc.data();
            if (data.users.includes(workerId)) {
                chatId = doc.id;
            }
        });
        
        if (chatId) {
            return res.status(200).json({ chatId });
        }
        
        // Create new chat
        const newChat = {
            users: [userId, workerId],
            lastMessage: '',
            timestamp: new Date().toISOString(),
            createdAt: new Date().toISOString()
        };
        
        const chatRef = await db.collection('chats').add(newChat);
        res.status(201).json({ chatId: chatRef.id });
    } catch (error) {
        console.error('Error starting chat:', error);
        res.status(500).json({ error: 'Error starting chat: ' + error.message });
    }
};
// Send a message
export const sendMessage = async (req, res) => {
    try {
        const { chatId, message } = req.body;
        const senderId = req.user.id; // Get sender ID from token
        
        if (!chatId || !message) {
            return res.status(400).json({ error: 'Missing required fields' });
        }
        
        // Verify chat exists and user is a participant
        const chatDoc = await db.collection('chats').doc(chatId).get();
        if (!chatDoc.exists) {
            return res.status(404).json({ error: 'Chat not found' });
        }
        
        const chatData = chatDoc.data();
        if (!chatData.users.includes(senderId)) {
            return res.status(403).json({ error: 'You are not authorized to send messages in this chat' });
        }
        
        // Create message with a unique ID
        const messageId = uuidv4();
        const messageData = {
            id: messageId,
            senderId,
            message,
            timestamp: new Date().toISOString(),
            read: false
        };
        
        // Add message to the chat's messages collection
        await db.collection('chats').doc(chatId).collection('messages').doc(messageId).set(messageData);
        
        // Update chat's last message and timestamp
        await db.collection('chats').doc(chatId).update({
            lastMessage: message,
            timestamp: new Date().toISOString()
        });
        
        res.status(201).json({ 
            success: true, 
            message: 'Message sent',
            messageId 
        });
    } catch (error) {
        console.error('Error sending message:', error);
        res.status(500).json({ error: 'Error sending message: ' + error.message });
    }
};
// Get messages of a chat
export const getMessages = async (req, res) => {
    try {
        const { chatId } = req.params;
        const userId = req.user.id;
        
        if (!chatId) {
            return res.status(400).json({ error: 'Chat ID is required' });
        }
        
        // Verify chat exists and user is a participant
        const chatDoc = await db.collection('chats').doc(chatId).get();
        if (!chatDoc.exists) {
            return res.status(404).json({ error: 'Chat not found' });
        }
        
        const chatData = chatDoc.data();
        if (!chatData.users.includes(userId)) {
            return res.status(403).json({ error: 'You are not authorized to view this chat' });
        }
        
        // Get messages
        const messagesSnapshot = await db.collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', 'asc')
            .get();
            
        const messages = messagesSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        
        res.status(200).json(messages);
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ error: 'Error fetching messages: ' + error.message });
    }
};
