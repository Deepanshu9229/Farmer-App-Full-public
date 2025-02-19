
import 'package:riverpod/riverpod.dart';

//define user model
class User{
  final String name;
  final String mobileNumber;

User({
  required this.name,
  required this.mobileNumber,
});
}

// Create a StateNotifier to manage the current user state
class CurrentUserNotifier extends StateNotifier<User?>{
  CurrentUserNotifier() : super(null);

  //set or update current user
  void setUser(User user){
    state = user;
  }
  // Clear the current user (e.g., on sign out)
  void clearUser() {
    state = null;
  }

}
//Using a StateNotifierProvider to expose the current user throughout your app.
// Expose the current user state as a provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier();
});