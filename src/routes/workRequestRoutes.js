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
import { 
  getWorkerWorkRequests 
} from '../controllers/workRequestController.js';

// Get all work requests for a specific worker (worker ID in params)
router.get('/worker/:workerId?', getWorkerWorkRequests);
import { 
  getWorkRequestById 
} from '../controllers/workRequestController.js';

// Get a specific work request by ID
router.get('/:requestId', getWorkRequestById);
