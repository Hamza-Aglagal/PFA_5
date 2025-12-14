package com.simstruct.backend.repository;

import com.simstruct.backend.entity.Friendship;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FriendshipRepository extends JpaRepository<Friendship, String> {

    // Find all accepted friendships for a user
    @Query("SELECT f FROM Friendship f WHERE (f.user.id = :userId OR f.friend.id = :userId) AND f.status = 'ACCEPTED'")
    List<Friendship> findAcceptedFriendships(@Param("userId") String userId);

    // Find pending requests received by user
    @Query("SELECT f FROM Friendship f WHERE f.friend.id = :userId AND f.status = 'PENDING'")
    List<Friendship> findPendingRequestsReceived(@Param("userId") String userId);

    // Find pending requests sent by user
    @Query("SELECT f FROM Friendship f WHERE f.user.id = :userId AND f.status = 'PENDING'")
    List<Friendship> findPendingRequestsSent(@Param("userId") String userId);

    // Check if friendship exists between two users
    @Query("SELECT f FROM Friendship f WHERE " +
           "((f.user.id = :userId1 AND f.friend.id = :userId2) OR " +
           "(f.user.id = :userId2 AND f.friend.id = :userId1))")
    Optional<Friendship> findByUsers(@Param("userId1") String userId1, @Param("userId2") String userId2);

    // Count friends for a user
    @Query("SELECT COUNT(f) FROM Friendship f WHERE (f.user.id = :userId OR f.friend.id = :userId) AND f.status = 'ACCEPTED'")
    long countFriends(@Param("userId") String userId);

    // Find all friendships (any status) for a user
    @Query("SELECT f FROM Friendship f WHERE f.user.id = :userId OR f.friend.id = :userId")
    List<Friendship> findAllByUserId(@Param("userId") String userId);
}
