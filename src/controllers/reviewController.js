// controllers/reviewController.js
import { db } from "../firebase.js";

// Modified addReview function
export const addReview = async (req, res) => {
    try {
        const { workerId } = req.params;
        const { rating, comment } = req.body;
        const userId = req.user.id; // From token

        if (userId === workerId) {
            return res.status(403).json({ error: "You cannot review yourself." });
        }
        
        if (!rating || rating < 1 || rating > 5) {
            return res.status(400).json({ error: "Rating must be between 1 and 5." });
        }

    
        
        // Check if worker exists in users collection
        const workerRef = db.collection("users").doc(workerId);
        const workerSnap = await workerRef.get();
        
        if (!workerSnap.exists) {
            return res.status(404).json({ error: "Worker not found." });
        }
        
        // Verify that the user is actually a worker
        const workerData = workerSnap.data();
        if (workerData.role !== 'worker') {
            return res.status(400).json({ error: "The specified user is not a worker." });
        }
        
        // Add review to Firestore in a reviews subcollection
        const reviewRef = await workerRef.collection("reviews").add({
            userId,
            rating,
            comment: comment || "",
            timestamp: new Date().toISOString(),
        });
        
        // Calculate new average rating
        const reviewsSnap = await workerRef.collection("reviews").get();
        let totalRating = 0;
        reviewsSnap.forEach(doc => totalRating += doc.data().rating);
        const newAvgRating = totalRating / reviewsSnap.size;
        
        // Update worker's average rating
        await workerRef.update({
            rating: newAvgRating,
            reviewsCount: reviewsSnap.size
        });
        
        res.status(201).json({ message: "Review added successfully!" });
    } catch (error) {
        res.status(500).json({ error: "Error adding review: " + error.message });
    }
};

