import 'package:mpflutter_build_tools/main.dart' as build_tools;

void main(List<String> arguments) async {
  final buildArgs = [...arguments]..add('--wechat');
  build_tools.licenseGrant = true;
  build_tools.main(buildArgs);
}
