class Client{

  final String columnUserId = 'USERID';
  final String columnUserEmail = 'USEREMAIL';
  final String columnUserPassword = 'USERPASSWORD';
  final String columnUsername = 'USERNAME';
  final String columnUserLastname = 'USERLASTNAME';
  final String columnTelephone = 'TELEPHONE';
  final String columnRoleId = 'USERROLEID';
  final String columnStatus = 'USERSTATUS';


  int id = 0;
  late String email;
  late String password;
  late String userName;
  late String userLastName;
  late String telephone;
  late int roleId;
  late String status;

  Client(
      this.email,
      this.password,
      this.userName,
      this.userLastName,
      this.telephone,
      this.roleId,
      this.status
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnUserEmail: email,
      columnUserPassword: password,
      columnUsername: userName,
      columnUserLastname: userLastName,
      columnTelephone: telephone,
      columnRoleId: roleId,
      columnStatus: status
    };
    return map;
  }

  Client.fromMap(Map<dynamic, dynamic> map){
    id = map[columnUserId];
    email = map[columnUserEmail];
    password = map[columnUserPassword];
    userName = map[columnUsername];
    userLastName = map[columnUserLastname];
    telephone = map[columnTelephone];
    roleId = map[columnRoleId];
    status = map[columnStatus];
  }
}