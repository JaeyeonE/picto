// service: api, database등 외부와 연결하는 코드

// class UserRepository {
//   final _apiService = ApiService();
  
//   Future<List<User>> getUsers() async {
//     final response = await _apiService.get('/users');
//     return response.map((json) => User.fromJson(json)).toList();
//   }
// }

// API 호출과 데이터 처리를 담당
// 데이터베이스 작업도 여기서 처리

