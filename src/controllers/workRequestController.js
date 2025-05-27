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

// Get work requests for a specific user (their own requests)
export const getUserWorkRequests = async (req, res) => {
  try {
    // Check if user is authenticated
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required to view work requests' });
    }

    // Get all work requests where userId matches the authenticated user
    const requestsSnapshot = await db.collection('workRequests')
      .where('userId', '==', req.user.id)
      .orderBy('createdAt', 'desc')
      .get();
    
    if (requestsSnapshot.empty) {
      return res.status(200).json({ message: 'No work requests found', requests: [] });
    }

    const requests = requestsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.status(200).json(requests);
  } catch (error) {
    res.status(500).json({ error: 'Error fetching user work requests: ' + error.message });
  }
};


// Get work requests for a specific worker
export const getWorkerWorkRequests = async (req, res) => {
  try {
    // Check if user is authenticated
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required to view work requests' });
    }

    // Verify that the authenticated user is a worker or checking their own requests
    if (req.user.role !== 'worker' && req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Only workers can view their work requests' });
    }

    const workerId = req.params.workerId || req.user.id;
    
    // If not admin and trying to view someone else's requests, block access
    if (req.user.role !== 'admin' && workerId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Get all work requests where workerId matches
    const requestsSnapshot = await db.collection('workRequests')
      .where('workerId', '==', workerId)
      .orderBy('createdAt', 'desc')
      .get();
    
    if (requestsSnapshot.empty) {
      return res.status(200).json({ message: 'No work requests found', requests: [] });
    }

    // Map each request and add requestId as 'id' in response
    const requests = requestsSnapshot.docs.map(doc => ({
      requestId: doc.id,  // Adding requestId field to the response
      ...doc.data()
    }));

    res.status(200).json(requests);
  } catch (error) {
    res.status(500).json({ error: 'Error fetching worker work requests: ' + error.message });
  }
};
