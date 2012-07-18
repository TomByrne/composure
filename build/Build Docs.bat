haxe -main composureTest.ClassIncluder -cp ../src -cp ../testSrc -lib hsl-1 -xml type-desc.xml
cd chxdoc

rd /s /q "../../github-wiki/docs"
chxdoc -o ../../github-wiki/docs --template=../github-wiki-template --includeOnly=composure.* ../type-desc.xml

cd ../../github-wiki/docs

del overview.html
del index.html
del all_packages.html
rd /s /q "packages"
rd /s /q "images"

ren "all_classes.html" "Documentation - All Classes.md"

for /r %%x in (*.html) do ren "%%x" *.md

cd ../../build