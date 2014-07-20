This is a basic load test suitable for any Drupal site.

Step 1:
./sitemap2csv.php http://example.com

This should create a file called urls.csv, that will look something like:
www.example.com,/blog/fun-stakeoutrb
www.example.com,/blog/unexpected-occurence-git-how-it-made-our-life-easier-time

As an alternative, if the site lacks a functioning sitemap you can generate URLs by crawling:
wget2csv.php http://example.com

Step 2:
./run.sh

Make sure that jmeter.sh is in your path.

Step 3:
cd tmp ; ../graph.py *csv

This will output a PNG file.  The graphing program requires matplotlib; it's best to install this on your workstation and run it there.