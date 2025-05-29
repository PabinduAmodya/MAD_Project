class User {
    constructor(name, email, password, phoneNo, role = 'user') {
      this.name = name;
      
      this.role = role;
      this.createdAt = new Date();
    }
  }
  
  export default User;
