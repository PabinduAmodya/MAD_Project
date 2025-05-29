import User from './userModel.js';

class Worker extends User {
  constructor(name, email, password, workType, location, yearsOfExperience, phoneNo) {
    // Fix the parameter order to match User constructor (name, email, password, phoneNo, role)
    super(name, email, password, phoneNo, 'worker'); 
    this.workType = workType;
    this.location = location;
    this.yearsOfExperience = yearsOfExperience;
  }
}

export default Worker;
