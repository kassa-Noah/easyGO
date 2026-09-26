import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Help & Support')),
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
              question: 'How do I book an interurban journey?',
              answer:
                  'Select a transport agency from the Home screen, choose Book a Trip, select Interurban Only or Door-to-Door, enter your journey information, choose an available trip and continue to payment.',
            ),

            const _FaqItem(
              question: 'How does Door-to-Door travel work?',
              answer:
                  'Door-to-Door combines a pickup taxi, the interurban transport service and a destination taxi into one coordinated journey. Taxi assignment information is displayed when the external taxi provider assigns a driver.',
            ),

            const _FaqItem(
              question: 'How is my traveler luggage tracked?',
              answer:
                  'Traveler luggage is linked to your confirmed booking. The transport agency updates its operational status as it moves through the journey. You can view the luggage associated with a booking or use the Track section.',
            ),

            const _FaqItem(
              question: 'Can I send a parcel without travelling?',
              answer:
                  'Yes. Independent parcel shipment is separate from traveler luggage. Open Track, choose Independent Parcel, then create a parcel shipment and select an available transport service.',
            ),

            const _FaqItem(
              question: 'What do the tracking statuses mean?',
              answer:
                  'The standard workflow is Registered, Received by Agency, Loaded, In Transit, Arrived, Ready for Collection and Delivered. The progress indicator represents operational stages and not GPS distance travelled.',
            ),

            const _FaqItem(
              question: 'Where can I find my digital ticket?',
              answer:
                  'Open Trips, select the relevant booking and choose View Digital Ticket. Cancelled bookings do not provide an active digital ticket.',
            ),

            const _FaqItem(
              question: 'What happens after I pay?',
              answer:
                  'The server confirms the booking once the payment has settled and issues the ticket and booking references you see on the confirmation screen. A parcel shipment needs no payment: it is registered when you submit it and gets its tracking reference immediately.',
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

            // This used to offer Email Support, Phone Support and Report a
            // Problem, and every one of them opened a dialog saying the channel
            // was not connected. A support address and telephone line are set up
            // at deployment, so there is nothing to offer here yet; the screen
            // says so and points at the one channel that does work.
            const Text(
              'easyGO support channels are configured when the platform is deployed, '
              'so no support email address, telephone line or in-app request form is '
              'available in this build. To reach the agency handling your journey, open '
              'it from the Home screen and choose Message Agency.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
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
        borderRadius: BorderRadius.circular(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
        color: AppColors.primaryLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.20),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'For issues related to an active trip, luggage or parcel, keep your booking or tracking reference available. This helps identify the relevant service record.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: AppColors.textSecondary,
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

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.help_outline, color: AppColors.primary),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
