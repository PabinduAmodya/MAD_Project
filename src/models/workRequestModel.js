class WorkRequest {
  constructor(userId, workerId, userName, userPhone, title, description, location, deadline, status = 'pending') {
    this.userId = userId;           
    this.workerId = workerId;       
    this.userName = userName;      
    this.userPhone = userPhone;     
    this.title = title;             
    this.description = description; 
    this.location = location;       
    this.deadline = deadline;       
    this.status = status;           
    this.createdAt = new Date();    
    this.updatedAt = new Date();    
    this.messages = [];             
  }

  // Add a message to the conversation
  addMessage(senderId, content) {
    this.messages.push({
      senderId,
      content,
      timestamp: new Date()
    });
    this.updateTimestamp();
  }

  // Update the status of the request
  updateStatus(newStatus) {
    const validStatuses = ['pending', 'accepted', 'rejected', 'completed', 'cancelled'];
    if (validStatuses.includes(newStatus)) {
      this.status = newStatus;
      this.updateTimestamp();
      return true;
    }
    return false;
  }

  // Update the timestamp
  updateTimestamp() {
    this.updatedAt = new Date();
  }
}

export default WorkRequest;