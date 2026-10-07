import pathlib
p = pathlib.Path('lib/screens')
for f in p.glob('*.dart'):
    name = ''.join([x.capitalize() for x in f.stem.split('_')])
    content = f"import 'package:flutter/material.dart';\nclass {name} extends StatelessWidget {{ const {name}({{super.key}}); @override Widget build(BuildContext context) {{ return Scaffold(appBar: AppBar(title: Text('{name}')), body: Center(child: Text('{name} Working'))); }} }}\n"
    open(f,'w', encoding='utf-8').write(content)
print("done")