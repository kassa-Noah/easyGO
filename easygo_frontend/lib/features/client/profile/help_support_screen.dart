import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({
    super.key,
  });

  void _showSupportInformation(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            message,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(),

            const SizedBox(height: 24),

            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Find answers to common questions about using easyGO.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            const _FaqItem(
              question:
                  'How do I book an interurban journey?',
              answer:
                  'Select a transport agency from the Home screen, choose Book a Trip, select Interurban Only or Door-to-Door, enter your journey information, choose an available trip and continue to payment.',
            ),

            const _FaqItem(
              question:
                  'How does Door-to-Door travel work?',
              answer:
                  'Door-to-Door combines a pickup taxi, the interurban transport service and a destination taxi into one coordinated journey. Taxi assignment information is displayed when the external taxi provider assigns a driver.',
            ),

            const _FaqItem(
              question:
                  'How is my traveler luggage tracked?',
              answer:
                  'Traveler luggage is linked to your confirmed booking. The transport agency updates its operational status as it moves through the journey. You can view the luggage associated with a booking or use the Track section.',
            ),

            const _FaqItem(
              question:
                  'Can I send a parcel without travelling?',
              answer:
                  'Yes. Independent parcel shipment is separate from traveler luggage. Open Track, choose Independent Parcel, then create a parcel shipment and select an available transport service.',
            ),

            const _FaqItem(
              question:
                  'What do the tracking statuses mean?',
              answer:
                  'The standard workflow is Registered, Received by Agency, Loaded, In Transit, Arrived, Ready for Collection and Delivered. The progress indicator represents operational stages and not GPS distance travelled.',
            ),

            const _FaqItem(
              question:
                  'Where can I find my digital ticket?',
              answer:
                  'Open Trips, select the relevant booking and choose View Digital Ticket. Cancelled bookings do not provide an active digital ticket.',
            ),

            const _FaqItem(
              question:
                  'What happens after I pay?',
              answer:
                  'After successful payment, the booking or parcel shipment is confirmed and the corresponding reference information is created. During backend integration, payment confirmation and reference generation will be performed by the server.',
            ),

            const SizedBox(height: 28),

            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Use the appropriate support channel when you need additional assistance.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            _SupportOption(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle:
                  'Contact the easyGO support service',
              onTap: () {
                _showSupportInformation(
                  context,
                  'Email Support',
                  'Direct email communication will be connected later. During backend and deployment integration, the official easyGO support address will be configured here.',
                );
              },
            ),

            const SizedBox(height: 12),

            _SupportOption(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle:
                  'Speak with the support service',
              onTap: () {
                _showSupportInformation(
                  context,
                  'Phone Support',
                  'The official easyGO support telephone number will be configured during deployment. No demonstration phone number is treated as an operational support line.',
                );
              },
            ),

            const SizedBox(height: 12),

            _SupportOption(
              icon:
                  Icons.chat_bubble_outline,
              title: 'Report a Problem',
              subtitle:
                  'Report a booking, tracking or application issue',
              onTap: () {
                _showSupportInformation(
                  context,
                  'Report a Problem',
                  'A support-request workflow can later send the issue category, description and authenticated client information to the backend support service.',
                );
              },
            ),

            const SizedBox(height: 24),

            _buildImportantNotice(),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.support_agent_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),

          SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Get assistance with travel, bookings, luggage and parcel tracking.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight
            .withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: AppColors.primaryLight
              .withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'For issues related to an active trip, luggage or parcel, keep your booking or tracking reference available. This helps identify the relevant service record.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(
          Icons.help_outline,
          color: AppColors.primary,
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportOption
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(
        15,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          15,
        ),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color:
                    AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}