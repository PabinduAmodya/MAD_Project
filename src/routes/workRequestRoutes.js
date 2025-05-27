import express from 'express';
import { 
  createWorkRequest, 
  getUserWorkRequests, 
  getWorkerWorkRequests, 
  getWorkRequestById, 
  updateWorkRequestStatus, 
  addWorkRequestMessage 
} from '../controllers/workRequestController.js';

const router = express.Router();

export default router;
