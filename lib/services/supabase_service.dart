import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<List> getTasks() async {
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', user.id)
        .order('created_at');

    return response;
  }

  Future addTask(String title) async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase.from('tasks').insert({
      'title': title,
      'is_completed': false,
      'user_id': user.id,
    });
  }

  Future deleteTask(int id) async {
    await supabase.from('tasks').delete().eq('id', id);
  }

  Future toggleTask(int id, bool completed) async {
    await supabase
        .from('tasks')
        .update({'is_completed': !completed})
        .eq('id', id);
  }

  Future updateTask(int id, String title) async {
    await supabase.from('tasks').update({'title': title}).eq('id', id);
  }
}
