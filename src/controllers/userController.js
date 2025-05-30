import { db } from '../firebase.js';
import User from '../models/userModel.js';
import Worker from '../models/workerModel.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export const registerUser = async (req, res) => {
  try {
    const { name, email, password, role, workType, location, yearsOfExperience, phoneNo } = req.body;

    // 🔹 Ensure required fields are provided
    if (!name || !email || !password || !phoneNo) {
      return res.status(400).json({ error: 'Name, email, password, and phone number are required!' });
    }

    // 🔹 Validate worker fields if registering as a worker
    if (role === 'worker' && (!workType || !location || !yearsOfExperience)) {
      return res.status(400).json({ error: 'Work type, location, and years of experience are required for workers!' });
    }

    // 🔹 Prevent unauthorized admin registration
    if (role === 'admin') {
      if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Only an admin can create another admin account!' });
      }
    }

    // 🔹 Check if the user already exists
    const userSnapshot = await db.collection('users').where('email', '==', email).get();
    if (!userSnapshot.empty) {
      return res.status(400).json({ error: 'User with this email already exists!' });
    }

    // 🔹 Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 🔹 Create a new user object based on role
    const newUser = (role === 'worker')
      ? new Worker(name, email, hashedPassword, workType, location, yearsOfExperience, phoneNo) // Include phoneNo
      : new User(name, email, hashedPassword, phoneNo); // Include phoneNo for user

// 🔹 Save user to Firestore
    const userRef = await db.collection('users').add({
      ...newUser,
      createdAt: new Date().toISOString()
    });

    if (!userRef.id) {
      throw new Error("User registration failed at Firestore");
    }

    // 🔹 Send success response
    return res.status(201).json({
      message: 'User registered successfully!',
      userId: userRef.id
    });

  } catch (error) {
    console.error('Registration Error:', error); // Log entire error object
    return res.status(500).json({ error: `Registration failed: ${error.message || error}` });
  }
};


export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      console.log("Email or password missing!");
      return res.status(400).json({ error: 'Email and password are required!' });
    }

    // Check if the user exists in Firestore
    const userSnapshot = await db.collection('users').where('email', '==', email).get();
    if (userSnapshot.empty) {
      console.log('User not found for email: ', email);
      return res.status(400).json({ error: 'User not found!' });
    }

    const userDoc = userSnapshot.docs[0];  // Get first matching document
    const user = userDoc.data();  // Get user data
    const userId = userDoc.id;  // Get Firestore document ID

    console.log("User found: ", userId);

    // Compare provided password with stored hashed password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.log('Password mismatch for user: ', email);
      return res.status(400).json({ error: 'Wrong Password!' });
    }

    // Respond with a token
    const token = jwt.sign({ id: userId, email: user.email, role: user.role }, process.env.JWT_SECRET || "Secret_Key-7973", { expiresIn: '1h' });
    
    console.log('Login successful for user: ', email);
    res.json({
      message: "Login successful!",
      token: token,
      user: {
        id: userId,  
        email: user.email,
        name: user.name,
        role: user.role
      }
    });
  } catch (error) {
    console.error("Error during login:", error);
    res.status(500).json({ error: 'Error logging in: ' + error.message });
  }
};
// Function to get all workers
export const getAllWorkers = async (req, res) => {


  
  try {
      const workersSnapshot = await db.collection('users').where('role', '==', 'worker').get();
      
      if (workersSnapshot.empty) {
          return res.status(404).json({ message: 'No workers found!' });
      }

      const workers = workersSnapshot.docs.map(doc => ({
          id: doc.id, 
          ...doc.data()  // Spread operator to include all worker details
      }));

      res.status(200).json(workers);
  } catch (error) {
      res.status(500).json({ error: 'Error fetching workers: ' + error.message });
  }
};
export const updateWorkerProfile = async (req, res) => {
  try {
    const { workerId } = req.params;
    const { name, email, phoneNo, workType, location, yearsOfExperience } = req.body;
    const requestingUserId = req.user.id; // From JWT token

    // Check if the requesting user is updating their own profile
    if (requestingUserId !== workerId) {
      return res.status(403).json({ error: 'You can only update your own profile!' });
    }

    // Get the user document
    const userRef = db.collection('users').doc(workerId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'Worker not found!' });
    }

    const userData = userDoc.data();

    // Check if the user is actually a worker
    if (userData.role !== 'worker') {
      return res.status(400).json({ error: 'Only workers can update worker profiles!' });
    }

    // Prepare update data
    const updateData = {};
    if (name) updateData.name = name;
    if (email) updateData.email = email;
    if (phoneNo) updateData.phoneNo = phoneNo;
    if (workType) updateData.workType = workType;
    if (location) updateData.location = location;
    if (yearsOfExperience) updateData.yearsOfExperience = yearsOfExperience;

    // Update the document
    await userRef.update({
      ...updateData,
      updatedAt: new Date().toISOString()
    });

    // Get the updated document to return
    const updatedDoc = await userRef.get();

    return res.status(200).json({
      message: 'Worker profile updated successfully!',
      worker: {
        id: updatedDoc.id,
        ...updatedDoc.data()
      }
    });

  } catch (error) {
    console.error('Update Worker Profile Error:', error);
    return res.status(500).json({ error: `Profile update failed: ${error.message || error}` });
  }
};

export const getWorkerProfile = async (req, res) => {
  try {
    const { workerId } = req.params;

    const workerDoc = await db.collection('users').doc(workerId).get();
    
    if (!workerDoc.exists) {
      return res.status(404).json({ error: 'Worker not found!' });
    }

    const workerData = workerDoc.data();

    if (workerData.role !== 'worker') {
      return res.status(400).json({ error: 'User is not a worker!' });
    }

    return res.status(200).json(workerData);

  } catch (error) {
    console.error('Get Worker Error:', error);
    return res.status(500).json({ error: `Failed to get worker: ${error.message || error}` });
  }
};
