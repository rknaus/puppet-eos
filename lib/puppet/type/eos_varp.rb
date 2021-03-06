#
# Copyright (c) 2015, Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#  Redistributions of source code must retain the above copyright notice,
#  this list of conditions and the following disclaimer.
#
#  Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the distribution.
#
#  Neither the name of Arista Networks nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# Work around due to autoloader issues: https://projects.puppetlabs.com/issues/4248
require File.dirname(__FILE__) + '/../../puppet_x/eos/utils/helpers'
require 'netaddr'

Puppet::Type.newtype(:eos_varp) do
  @doc = <<-EOS
    Manage global VARP settings on Arista EOS. Configure the Virtual-ARP mac
    address.

    Example:

        eos_varp { 'settings':
            mac_address => '001c.7300.0099',
        }
  EOS

  ensurable

  def munge_mac_address(value)
    begin
      addr = NetAddr::EUI.create(value)
    rescue
      raise "value #{value.inspect} is invalid, must be a mac address."
    end
    addr.address(Delimiter: ':')
  end

  # Parameters

  newparam(:name, namevar: true) do
    desc <<-EOS
      Resource name defaults to 'settings' and is not used to configure EOS.
      Returns an error if a name other than 'settings' is specified.
    EOS

    validate do |value|
      unless value.is_a? String
        fail "value #{value.inspect} is invalid, must be a String."
      end
      unless value == 'settings'
        fail "value #{value.inspect} is invalid, namevar must be 'settings'."
      end
    end
  end

  # Properties (state management)

  newproperty(:mac_address) do
    desc <<-EOS
      Assigns a virtual MAC address to the switch.
    EOS

    munge do |value|
      @resource.munge_mac_address(value)
    end

    validate do |value|
      unless value.is_a? String
        fail "value #{value.inspect} is invalid, must be a String."
      end
    end
  end
end
