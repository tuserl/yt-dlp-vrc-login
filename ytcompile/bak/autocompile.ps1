mkdir .\ytnew\

cd .\ytnew\
git clone https://github.com/yt-dlp/yt-dlp
cd .\yt-dlp\

cp ..\..\..\yt_dlp\__main__.py .\yt_dlp\__main__.py

python3 devscripts/install_deps.py --include pyinstaller
python3 devscripts/make_lazy_extractors.py
python3 -m bundle.pyinstaller

mv .\dist\yt-dlp.exe ../
