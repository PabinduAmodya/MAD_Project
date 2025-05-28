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
    // Convert deadline to Date format if provided, otherwise set it to null
    const safeDeadline = deadline ? new Date(deadline) : null;

    // Create a new work request 
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
