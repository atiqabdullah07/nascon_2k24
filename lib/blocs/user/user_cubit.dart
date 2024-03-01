import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

import '../../core/exceptions.dart';
import '../../models/chat.dart';
import '../../models/user.dart';
import '../../models/user_overview.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");
  final Reference _pfpsRef = FirebaseStorage.instance.ref("pfps");
  late StreamSubscription<DatabaseEvent> _userStream;

  UserCubit() : super(UserInitial());

  /// Initializer
  ///
  void initializer(String authenticatedUserId) async {
    try {
      final userRef = _usersRef.child(authenticatedUserId);

      /// listen to user stream
      _userStream = userRef.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<Object?, Object?>;
          final userAttributes = Map<String, Object?>.from(data);
          final user = User.fromMap(userAttributes);

          if (user.chats != null) {
            // sort chats
            user.chats?.sort((e, f) =>
                e.lastMessage != null && f.lastMessage != null
                    ? e.lastMessage!.sent.compareTo(f.lastMessage!.sent)
                    : 0);

            final updatedUser =
                user.copyWith(chats: user.chats?.reversed.toList());

            emit(UserFetched(user: updatedUser));
          } else {
            emit(UserFetched(user: user));
          }
        }
      });
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        UserException(
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  /// Dispose Resources
  /// must call when closing user cubit
  void dispose() async {
    await _userStream.cancel();

    emit(UserReset());
  }

  ///
  /// Create User
  ///
  void createUser({
    required String uid,
    required String email,
    required XFile pfp,
    required String displayName,
    required String education,
    required String location,
  }) async {
    try {
      emit(UserProcessing(user: state.user));

      // get the user reference
      final userRef = _usersRef.child(uid);
      final userPfpRef = _pfpsRef.child(uid);

      // upload the pfp and get the downloadable url
      await userPfpRef.putFile(File(pfp.path));
      final pfpUrl = await userPfpRef.getDownloadURL();

      // create new user
      final newUser = User(
        id: uid,
        email: email,
        pfp: pfpUrl,
        username: displayName,
        location: location,
        education: education,
        rating: 0,
        reviewsCount: 0,
        responseTime: 0,
      );

      // put it in database
      await userRef.set(newUser.toMap());

      emit(UserCreated(user: newUser));
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        UserException(
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  /// Update the bidden jobs of the user as seeker, requires Job Id
  void updatedBiddenJobs(String jid) async {
    try {
      if (state.user?.biddenJobs?.contains(jid) ?? false) return;

      emit(UserProcessing(user: state.user));

      // get the user reference
      final userRef = _usersRef.child(state.user!.id);

      // update the user
      final updatedUser = state.user!.copyWith(
        biddenJobs: [jid, ...?state.user?.biddenJobs],
      );

      await userRef.set(updatedUser.toMap());
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        UserException(
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }
  }

  /// Check if that signed up also created user record in realtime database,
  /// the user record is necessary as the user model that operates across the
  /// application depends on the data from the user record in realtime database
  Future<bool> doesUserRecordExists(String uid) async {
    try {
      // get the ref to user in database
      final userSnapshot = await _usersRef.child(uid).get();

      return userSnapshot.value != null; // is there any data for user
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(
        UserException(
          exception: RemoteException(
            message: '${exception.message}',
            code: int.tryParse(exception.code) ?? 500,
          ),
        ),
      );
    }

    return false;
  }

  /// Toggle Favourite Seeker
  void toggleFavouriteSeeker(UserOverview favourite) async {
    try {
      final userRef = _usersRef.child(state.user!.id);
      final updatedFavourites = [...?state.user?.favouriteSeekers];

      if (isFavouriteSeeker(favourite.id)) {
        updatedFavourites.remove(favourite);
      } else {
        updatedFavourites.add(favourite);
      }

      final updatedUser =
          state.user?.copyWith(favouriteSeekers: updatedFavourites);
      await userRef.set(updatedUser?.toMap());

      /// on exception
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(UserException(
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }

  /// Toggle Favourite Job
  void toggleFavouriteJob(String favourite) async {
    try {
      final userRef = _usersRef.child(state.user!.id);
      final updatedFavourites = [...?state.user?.favouriteJobs];

      if (isFavouriteJob(favourite)) {
        updatedFavourites.remove(favourite);
      } else {
        updatedFavourites.add(favourite);
      }

      final updatedUser =
          state.user?.copyWith(favouriteJobs: updatedFavourites);
      await userRef.set(updatedUser?.toMap());

      /// on exception
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(UserException(
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }

  /// This function should only be used after checking if the chatroom
  /// for both users is already created or not, using [isChatRoomPresent] api.
  void createChat({required User seeker}) async {
    try {
      // create ref to new chat
      final myRef = _usersRef.child(state.user!.id);
      final seekerRef = _usersRef.child(seeker.id);
      final newChatRef = myRef.child("chats").push();

      if (newChatRef.key != null) {
        // create new chat
        final otherUser = UserOverview(
          id: seeker.id,
          name: seeker.username,
          rating: seeker.rating,
          pfpUrl: seeker.pfp,
          location: seeker.location,
        );
        final me = UserOverview(
          id: state.user!.id,
          name: state.user!.username,
          rating: state.user!.rating,
          pfpUrl: state.user!.pfp,
          location: state.user!.location,
        );

        final newChat = Chat(
          id: newChatRef.key!,
          sender: me,
          receiver: otherUser,
        );

        /// create updated users
        final updatedSeeker =
            seeker.copyWith(chats: [...?seeker.chats, newChat]);
        final updatedMe =
            state.user!.copyWith(chats: [...?state.user!.chats, newChat]);

        /// update users in realtime database
        await myRef.set(updatedMe.toMap());
        await seekerRef.set(updatedSeeker.toMap());
      }
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(UserException(
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }

  /// toggle chat favourite status
  void toggleFavouriteChat(String cid) async {
    try {
      final chatIndex = state.user?.chats?.indexWhere((c) => c.id == cid) ?? -1;

      if (chatIndex != -1) {
        // get the chat
        final chat = state.user!.chats![chatIndex];

        /// update the last message now in sender chat
        final chatRef =
            _usersRef.child(state.user!.id).child("chats").child(cid);

        await chatRef.update({"isFavourite": !chat.isFavourite});
      }

      /// on any exception
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(UserException(
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }

  /// is Favourite Seeker
  bool isFavouriteSeeker(String uid) {
    return state.user?.favouriteSeekers?.any((user) => user.id == uid) ?? false;
  }

  /// is Favourite Seeker
  bool isFavouriteJob(String jid) {
    return state.user?.favouriteJobs?.any((job) => job == jid) ?? false;
  }

  /// Is Chat Room already created
  String? isChatRoomPresent(String other) {
    final chatIndex = state.user?.chats?.indexWhere(
      (c) => c.receiver.id == other || c.sender.id == other,
    );

    if (chatIndex != -1 && chatIndex != null) {
      return state.user?.chats?[chatIndex].id;
    } else {
      return null;
    }
  }

  /// Update User about / Bio String
  void updateAbout({required String about}) async {
    try {
      /// get the reference to the user
      final userRef = _usersRef.child(state.user!.id);

      await userRef.update({
        "about": about.trim(),
      });

      /// on any exception
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(UserException(
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }

  void updateRating({required double rating}) async {
    try {
      /// get the reference to the user
      final userRef = _usersRef.child(state.user!.id);

      final updatedReviewsCount = state.user!.reviewsCount + 1;
      final updatedRating =
          ((state.user!.rating * state.user!.reviewsCount) + rating) /
              updatedReviewsCount;

      await userRef.update({
        "rating": updatedRating,
        "reviewsCount": updatedReviewsCount,
      });

      /// on any exception
    } on TaskMakerException catch (exception) {
      emit(UserException(exception: exception));
    } on FirebaseException catch (exception) {
      emit(UserException(
        exception: RemoteException(
          message: "${exception.message}",
          code: int.tryParse(exception.code) ?? 500,
        ),
      ));
    }
  }
}
