import express from 'express';
import { startChat, sendMessage, getMessages, markMessagesAsRead, getWorkerChats } from '../controllers/chatController.js';

const router = express.Router();

// Start a new chat (or get existing chat)
router.post('/start', startChat);

// Send a message
router.post('/send', sendMessage);

// Get messages for a chat
router.get('/:chatId/messages', getMessages);

// Mark messages as read
router.put('/:chatId/read', markMessagesAsRead);

// Add this route
router.get('/worker/:workerId', getWorkerChats);

export default router;
