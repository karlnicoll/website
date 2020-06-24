---
layout: post
title: Installing Sphinx Doc in CentOS 6
permalink: /installing-sphinx-doc-in-centos-6/
---
Recently I have been working on a C++ project where the project documentation
is created using [sphinx-doc](http://www.sphinx-doc.org/). The documentation
is compiled as part of the application build process, but doesn't build on
old versions of Sphinx. This posed a problem with doing builds of the project
on CentOS 6, because the version of Sphinx that is available through EPEL is
*ancient*, and thus did not support the directives used in the documentation.

The solution is to install a newer version of Sphinx, but instead of using the
CentOS repositories, install through Python's `pip` utility instead. This
allows us to install the most up to date pip-released version of Sphinx.

First, it is necessary to install Python 3, along with the associated
`devel` and `setuptools` packages:

```shell
$ yum install python34 python34-devel python34-setuptools
...
```

Once the Python packages are installed, it is necessary to build `pip`:

```shell
$ cd /usr/lib/python3.4/site-packages/
...
$ python3 easy_install.py pip
...
```

Finally, use pip to install Sphinx:

```shell
$ pip install sphinx
...
```

This should give you a much more up-to-date version of Sphinx than the one that
is provided through EPEL:

```shell
$ sphinx-build --version
sphinx-build 1.8.5
```
