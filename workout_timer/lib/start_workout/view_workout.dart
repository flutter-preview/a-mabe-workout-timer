import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../create_workout/create_timer.dart';
import '../create_workout/create_workout.dart';
import '../database/database_manager.dart';
import '../models/list_model.dart';
import '../workout_type/workout_type.dart';
import '../widgets/card_item.dart';
import '../models/list_tile_model.dart';
import 'workout.dart';

class ViewWorkout extends StatefulWidget {
  const ViewWorkout({super.key});
  @override
  ViewWorkoutState createState() => ViewWorkoutState();
}

class ViewWorkoutState extends State<ViewWorkout> {
  late ListModel<ListTileModel> intervalInfo;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void pushCreateWorkout(workout) {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateWorkout(),
          settings: RouteSettings(
            arguments: workout,
          ),
        ),
      );
    });
  }

  void pushCreateTimer(workout) {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateTimer(),
          settings: RouteSettings(
            arguments: workout,
          ),
        ),
      );
    });
  }

  List<ListTileModel> listItems(List exercises, Workout workoutArgument) {
    List<ListTileModel> listItems = [];

    for (var i = 0; i < workoutArgument.numExercises + 1; i++) {
      // message.write('!');
      // intervalInfo.insert(i + 1, exercises[i]);
      print("Initialize list items");
      print(workoutArgument.numExercises);
      print(exercises.length);
      print(i);
      if (i == 0) {
        listItems.add(ListTileModel(
            action: "Prepare",
            interval: 0,
            total: workoutArgument.numExercises,
            seconds: 10));
      } else {
        if (exercises.length < workoutArgument.numExercises) {
          listItems.add(ListTileModel(
              action: "Work",
              interval: i,
              total: workoutArgument.numExercises,
              seconds: workoutArgument.exerciseTime));
          if (i < workoutArgument.numExercises) {
            listItems.add(ListTileModel(
                action: "Rest",
                interval: 0,
                total: workoutArgument.numExercises,
                seconds: workoutArgument.restTime));
          }
        } else {
          listItems.add(ListTileModel(
              action: exercises[i - 1],
              interval: i,
              total: workoutArgument.numExercises,
              seconds: workoutArgument.exerciseTime));
          if (i < workoutArgument.numExercises) {
            listItems.add(ListTileModel(
                action: "Rest",
                interval: 0,
                total: workoutArgument.numExercises,
                seconds: workoutArgument.restTime));
          }
        }
      }

      print("Added");
    }

    return listItems;
  }

  @override
  void initState() {
    super.initState();
    intervalInfo = ListModel<ListTileModel>(
      listKey: _listKey,
      initialItems: <ListTileModel>[],
    );
  }

  @override
  Widget build(BuildContext context) {
    Workout workoutArgument =
        ModalRoute.of(context)!.settings.arguments as Workout;

    List<dynamic> exercises = workoutArgument.exercises != ""
        ? jsonDecode(workoutArgument.exercises)
        : [];
    Future<Database> database = DatabaseManager().initDB();

    Widget exerciseList() {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: intervalInfo.length,
        itemBuilder: (BuildContext context, int index) {
          return CardItem(item: intervalInfo[index]);
          // return SizedBox(
          //   height: 50,
          //   child: Center(child: Text(exercises[index])),
          // );
        },
      );
    }

    if (intervalInfo.length == 0) {
      intervalInfo = ListModel<ListTileModel>(
        listKey: _listKey,
        initialItems: listItems(exercises, workoutArgument),
      );
      print(intervalInfo.length);
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Show Snackbar',
            onPressed: () async {
              await DatabaseManager()
                  .deleteList(workoutArgument.id, database)
                  .then((value) {
                Navigator.pop(context);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (exercises.isEmpty) {
                pushCreateTimer(workoutArgument);
              } else {
                pushCreateWorkout(workoutArgument);
              }
            },
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80.0),
            child: Row(
              children: [
                // Expanded(
                //   flex: 1,
                //   child: Container(
                //     height: 80.0,
                //     width: MediaQuery.of(context).size.width * 0.25,
                //     color: Colors.red,
                //   ),
                // ),
                // Expanded(
                //   flex: 1,
                //   child: Container(
                //     height: 80.0,
                //     width: MediaQuery.of(context).size.width * 0.25,
                //     color: Colors.blue,
                //   ),
                // ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StartWorkout(),
                          settings: RouteSettings(
                            arguments: workoutArgument,
                          ),
                        ),
                      );
                    },
                    child: Ink(
                        height: 80.0,
                        width: MediaQuery.of(context).size.width * 0.25,
                        color: Colors.green,
                        child: const Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            Text("Start")
                          ],
                        ))),
                  ),
                ),
              ],
            )),
      ),
      body: Center(
        child: exerciseList(),
      ),
    );
  }
}
