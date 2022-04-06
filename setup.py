#! /usr/bin/env python
# -*- coding: utf8 -*-


import os
import io
from setuptools import setup


def getreadme():
    for fname in ('README.rst','README.md', 'README'):
        if os.path.exists(fname):
            return io.open(os.path.join(os.path.dirname(__file__), fname),'r',encoding='utf-8').read()
    return ""

setup(
    name = "Frog Webservice",
    version = "0.2", #make sure SYSTEM_VERSION in your service configuration is set to the same value!
    author = "Maarten van Gompel", #adapt this
    description = ("Frog is a suite containing a tokeniser, Part-of-Speech tagger, lemmatiser, morphological analyser, shallow parser, and dependency parser for Dutch. This is the webservice for it, for both humans and machines."),
    license = "GPLv3",
    keywords = "clam webservice rest nlp computational_linguistics rest",
    url = "https://languagemachines.github.io/frog", #update this!
    packages=['frog_webservice'],
    long_description=getreadme(),
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        "Topic :: Text Processing :: Linguistic",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Operating System :: POSIX",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    ],
    package_data = {'frog_webservice':['*.wsgi','*.yml','*.sh'] },
    include_package_data=True,
    install_requires=['CLAM >= 3.1.2', 'FoLiA-tools'] #Frog is also required but is an external dependency that setuptools can't handle, we specify it in codemeta-harvest.json for metadata harvesting purposes
)
