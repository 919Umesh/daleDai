import 'package:flutter/material.dart';
import 'package:omspos/screen/home/ui/widget/resort_card.dart';
import 'package:omspos/screen/properties/state/properties_state.dart';
import 'package:omspos/screen/properties/ui/widget/properties_card.dart';
import 'package:provider/provider.dart';

class PropertiesScreen extends StatefulWidget {
  final String? areaId;

  const PropertiesScreen({super.key, this.areaId});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<PropertiesState>(context, listen: false);
      if (widget.areaId != null) {
        state.loadPropertiesByArea(widget.areaId!);
      } else {
        state.loadAllProperties();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertiesState>(builder: (context, state, child) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                'Properties',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // so it scrolls with parent CustomScrollView
                    itemCount: state.properties.length,
                    itemBuilder: (context, index) {
                      final property = state.properties[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: InkWell(
                          onTap: () {},
                          child: PropertiesCard(
                            property: property,
                          ),
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
