#
# Copyright 2023-2023 Ghent University
#
# This file is part of vsc-administration,
# originally created by the HPC team of Ghent University (http://ugent.be/hpc/en),
# with support of Ghent University (http://ugent.be/hpc),
# the Flemish Supercomputer Centre (VSC) (https://www.vscentrum.be),
# the Flemish Research Foundation (FWO) (http://www.fwo.be/en)
# and the Department of Economy, Science and Innovation (EWI) (http://www.ewi-vlaanderen.be/en).
#
# https://github.com/hpcugent/vsc-administration
#
# All rights reserved.
#
"""
This module provides the command-line interface for vsc-administration
"""

from vsc.administration.cli.sync_slurm_ap import sync_slurm_acct_main as sync_slurm_acct_main
from vsc.administration.cli.sync_vsc_users import sync_vsc_users_main as sync_vsc_users_main
from vsc.administration.cli.sync_vsc_email_postfix import sync_vsc_email_postfix_main as sync_vsc_email_postfix_main
from vsc.administration.cli.sync_slurm_external_licenses import sync_slurm_external_licenses_main as sync_slurm_external_licenses_main
from vsc.administration.cli.replicate_scratch_tree import replicate_scratch_tree_main as replicate_scratch_tree_main
from vsc.administration.cli.create_tier2_ugent_home_data_directory_tree import create_tier2_ugent_home_data_directory_tree_main as create_tier2_ugent_home_data_directory_tree_main
