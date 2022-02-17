#!/usr/bin/env python3

import clam.clamservice
import frog_webservice.frog_webservice as service
application = clam.clamservice.run_wsgi(service)

