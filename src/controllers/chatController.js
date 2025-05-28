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
