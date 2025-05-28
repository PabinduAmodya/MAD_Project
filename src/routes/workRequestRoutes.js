import express from 'express';
import { 
  createWorkRequest, 
  getUserWorkRequests
} from '../controllers/workRequestController.js';

const router = express.Router();

// Create a new work request
router.post('/', createWorkRequest);

// Get all work requests for the logged-in user
router.get('/user', getUserWorkRequests);

export default router;
