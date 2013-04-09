2013-04-09
----------

- Buy and sell implemented.
- Minor tweaks as listed below:
    1. Minimum length of message must be 20.
    2. Categories passed will be lowercase.
    3. Previously `readall` command repeated a particular message for all subsequent tables.
- Help file updated with new commands.
- Changed `INNER JOIN` syntax for `dl` command to `LEFT JOIN` to allow deletions for entries without magnets. Using the same to delete replies for Buy and Sell.
- Original users will be notified of any mesages/replies on their buy and sell thread.

2013-04-07
----------

- Create Buy and Sell feature
- Chage git configuration for `core.autocrlf`
- Use IST for dates in chagelogs.

2013-04-06
----------

- Shorten infobot.lua
  1. Change logic.
  2. Remove redundancy.

2013-04-05
----------

- Web-branch updated to use jQuery 1.9.1 now.

2013-04-04
----------

- Added SQL table schema for latest and chat stats.
- Created web-page and web-branch.

2013-04-03
----------

- Infobot updated

2013-04-02
----------

- First commit
- Readme added
- Offliner and Info BOT scripts added.
- File reporting script added.
