import { db } from '../firebase.js';
import WorkRequest from '../models/workRequestModel.js';

// Create a new work request
export const createWorkRequest = async (req, res) => {
  try {
    // Check if user is authenticated
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required to create work requests' });
    }

    const { workerId,userName,userPhone, title, description, location, deadline } = req.body;

    // Validate required fields
    if (!workerId || !title || !description || !location) {
      return res.status(400).json({ error: 'Worker ID, title, description, and location are required!' });
    }

    // Verify that the worker exists
    const workerDoc = await db.collection('users').doc(workerId).get();
    if (!workerDoc.exists || workerDoc.data().role !== 'worker') {
      return res.status(404).json({ error: 'Worker not found!' });
    }

    
    const safeDeadline = deadline ? new Date(deadline) : null;

    
    const workRequest = new WorkRequest(
      req.user.id,
      workerId,
      userName,
      userPhone,
      title,
      description,
      location,
      safeDeadline
    );

    // Prepare work request data, avoiding undefined fields
    const workRequestData = {
      userId: workRequest.userId,
      workerId: workRequest.workerId,
      title: workRequest.title,
      userName : workRequest.userName,
      userPhone : workRequest.userPhone,
      description: workRequest.description,
      location: workRequest.location,
      status: workRequest.status,
      createdAt: workRequest.createdAt,
      updatedAt: workRequest.updatedAt,
      messages: workRequest.messages
    };

    // Only add deadline if it's not null
    if (workRequest.deadline) {
      workRequestData.deadline = workRequest.deadline;
    }

    // Save to Firestore
    const requestRef = await db.collection('workRequests').add(workRequestData);

    res.status(201).json({
      message: 'Work request created successfully!',
      requestId: requestRef.id
    });

  } catch (error) {
    res.status(500).json({ error: 'Error creating work request: ' + error.message });
  }
};