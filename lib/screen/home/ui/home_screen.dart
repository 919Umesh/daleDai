import 'package:flutter/material.dart';
import 'package:omspos/screen/home/state/home_state.dart';
import 'package:omspos/themes/fonts_style.dart';
import 'package:omspos/widgets/no_data_widget.dart';
import 'package:provider/provider.dart';

import 'package:omspos/widgets/container_decoration.dart';
import 'package:omspos/widgets/tablewidgets/header_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<HomeState>(context, listen: false).getContext = context;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(builder: (context, state, child) {
      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("Areas"),
            ),
            body: Column(
              children: [
                TableHeaderWidget(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "S.N:",
                          style: tableHeaderTextStyle,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Area",
                          style: tableHeaderTextStyle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "ID",
                          style: tableHeaderTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: state.areas.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.areas.length,
                          itemBuilder: (context, index) {
                            final area = state.areas[index];
                            return Container(
                              decoration: ContainerDecoration.decoration(),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${index + 1}.',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          if (area.areaImage != null)
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundImage:
                                                  NetworkImage(area.areaImage!),
                                            )
                                          else
                                            const CircleAvatar(
                                              radius: 16,
                                              child: Icon(Icons.location_on,
                                                  size: 16),
                                            ),
                                          const SizedBox(width: 8),
                                          Text(area.name),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        area.areaId.substring(0, 6) + '...',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const NoDataWidget(),
                ),
              ],
            ),
          ),
          if (state.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      );
    });
  }
}
