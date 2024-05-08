class Role{

  final String columnRoleId = 'ROLEID';
  final String columnRoleName = 'ROLENAME';

  int id = 0;
  late String roleName;

  Role(
      this.roleName
      );

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnRoleName: roleName,
    };
    return map;
  }

  Role.fromMap(Map<dynamic, dynamic> map){
    id = map[columnRoleId];
    roleName = map[columnRoleName];
  }
}