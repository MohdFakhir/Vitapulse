import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/reminder_entity.dart';
import '../bloc/reminders_bloc.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RemindersBloc>().add(LoadReminders());
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool repeatDaily = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('New Reminder', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Reminder Title',
                    hint: 'e.g., Drink water',
                    controller: titleController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time', style: TextStyle(color: AppColors.textPrimary)),
                      TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.primary,
                                    surface: AppColors.surface,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                        child: Text(
                          selectedTime.format(context),
                          style: const TextStyle(color: AppColors.primary, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Repeat Daily', style: TextStyle(color: AppColors.textPrimary)),
                      Switch(
                        value: repeatDaily,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => repeatDaily = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Save Reminder',
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        final now = DateTime.now();
                        final reminderTime = DateTime(
                          now.year, now.month, now.day,
                          selectedTime.hour, selectedTime.minute,
                        );
                        
                        context.read<RemindersBloc>().add(
                          AddReminder(
                            ReminderEntity(
                              id: '', // Will be set by repo
                              title: titleController.text.trim(),
                              time: reminderTime,
                              repeatDaily: repeatDaily,
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddReminderDialog(context),
      ),
      body: BlocBuilder<RemindersBloc, RemindersState>(
        builder: (context, state) {
          if (state is RemindersLoading || state is RemindersInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is RemindersError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
          } else if (state is RemindersLoaded) {
            if (state.reminders.isEmpty) {
              return Center(
                child: Text(
                  'No reminders set.\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.reminders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = state.reminders[index];
                return Dismissible(
                  key: Key(reminder.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<RemindersBloc>().add(DeleteReminder(reminder.id));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('hh:mm a').format(reminder.time)}${reminder.repeatDaily ? ' • Daily' : ''}',
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: reminder.isEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (_) {
                            context.read<RemindersBloc>().add(ToggleReminder(reminder));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
