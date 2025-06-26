import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String userPhone;
  final String userName;
  final String gigId;
  final double rating;
  final String? profileImageUrl;
  final VoidCallback onEditProfile;

  const ProfileHeaderCard({
    super.key,
    required this.userPhone,
    required this.userName,
    required this.gigId,
    required this.rating,
    this.profileImageUrl,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 91, 42, 134),
            const Color.fromARGB(255, 91, 42, 134).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 91, 42, 134).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Avatar
              Hero(
                tag: 'profile_avatar',
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gig ID: $gigId',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userPhone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Edit Button
              IconButton(
                onPressed: onEditProfile,
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Rating and Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.star,
                  label: 'Rating',
                  value: rating.toStringAsFixed(1),
                  iconColor: Colors.amber,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  icon: Icons.work_outline,
                  label: 'Gigs',
                  value: '24', // This would come from backend
                  iconColor: Colors.white,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  icon: Icons.verified,
                  label: 'Status',
                  value: 'Active',
                  iconColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}