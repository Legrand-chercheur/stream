import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MyAudioListScreen extends StatefulWidget {
  const MyAudioListScreen({Key? key}) : super(key: key);
  @override
  State<MyAudioListScreen> createState() => _MyAudioListScreenState();
}

class _MyAudioListScreenState extends State<MyAudioListScreen> {
  // bg color
  Color bgColor = Colors.brown;

  //define on audio plugin
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 55, 79, 1),
        title: Text(
          'StreamIt.',
          style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(249, 175, 24, 1)), // Ajout de cette ligne
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
            child: FutureBuilder<List<SongModel>>(
              //default values
              future: _audioQuery.querySongs(
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true,
              ),
              builder: (context, item){
                //loading content indicator
                if(item.data == null){
                  return const Center(child: CircularProgressIndicator(color: Color.fromRGBO(249, 175, 24, 1),),);
                }
                //no songs found
                if(item.data!.isEmpty){
                  return const Center(child: Text("No Songs Found"),);
                }

                // You can use [item.data!] direct or you can create a list of songs as
                // List<SongModel> songs = item.data!;
                //showing the songs
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: item.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: item.data![index].id,
                        type: ArtworkType.AUDIO,
                        artworkBorder: BorderRadius.circular(5),
                        size: 300,
                      ),
                      title: Text(
                        item.data![index].title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        item.data![index].displayName,
                        style: TextStyle(color: Colors.white54),
                      ),
                      trailing: CupertinoButton(child: Icon(Icons.play_arrow, color: Colors.white,), onPressed: (){
                        _audioPlayer.setFilePath(item.data![index].data);
                        _audioPlayer.play();
                      }),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  //define a toast method
  void toast(BuildContext context, String text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
    ));
  }

  void requestStoragePermission() async {
    //only if the platform is not web, coz web have no permissions
    if(!kIsWeb){
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if(!permissionStatus){
        await _audioQuery.permissionsRequest();
      }

      //ensure build method is called
      setState(() { });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


}