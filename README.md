Graphy: A Graph Library for Ruby
================================

Ongoing work to modernize the Graphy library. See the original work, as well as the previous generations.

[![Build Status](https://travis-ci.org/ic/graphy.png)](https://travis-ci.org/ic/graphy)

Important Note & Status
-----------------------

The goal here is to provide a modern package to a graph library. I have selected Graphy over its parents GRATR and RGL as it seems more modern already. For now the test suite is almost repaired, but I did not check it in detail, so I do not have much confidence in this code yet. And you should not either!

At this point:
* Most tests pass, except a few failures I am to check quickly.
* Replaced the priority queue implementation by the one in the Algorithms gem, so that install is easier (and we may expect some bug fixes).

