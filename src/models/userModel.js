class User {
    constructor(name, email, password, phoneNo, role = 'user') {
      this.name = name;
       this.email = email;
      this.password = password;
      this.phoneNo=phoneNo;
      this.role = role;
      this.createdAt = new Date();
    }
  }
  
  export default User;
