//login exceptions
 class UserNotFoundAuthException implements Exception {}
 class WrongPasswordAuthException implements Exception {}
// Register Exception
class WeakPasswordAuthException implements Exception {}
class EmailAlreadyInUseAuthException implements Exception {}
class InvalidEmailAuthException implements Exception {}
//generic exceptions
class GenericAuthException implements Exception{}
class UserNotLoggedInException implements Exception{}
