# encoding: utf-8
#
# Copyright (C) 2008-2013 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'trema'

[SetEthSrcAddr, SetEthDstAddr].each do |klass|
  describe klass, '.new', :type => 'actions' do
    subject { klass.new(mac_address) }

    context 'with "11:22:33:44:55:66"' do
      let(:mac_address) { '11:22:33:44:55:66' }

      describe '#mac_address' do
        subject { super().mac_address }
        it { is_expected.to eq '11:22:33:44:55:66' }
      end

      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq "#{ klass }: mac_address=11:22:33:44:55:66" }
      end

      context "when set as FlowMod's action", :sudo => true do
        it 'should insert a new flow with action (mod_dl_{src,dst}:11:22:33:44:55:66)' do
          class TestController < Controller; end
          network do
            vswitch { datapath_id 0xabc }
          end.run(TestController) do
            controller('TestController').send_flow_mod_add(0xabc, :actions => subject)
            sleep 2
            expect(vswitch('0xabc').flows.size).to eq(1)
            expect(vswitch('0xabc').flows[0].actions).to match(/mod_dl_(src|dst):11:22:33:44:55:66/)
            pending('Test actions as an object using Trema::Switch')
            expect(vswitch('0xabc').flows.size).to eq(1)
            expect(vswitch('0xabc').flows[0].actions.size).to eq(1)
            expect(vswitch('0xabc').flows[0].actions[0]).to be_a(klass)
            expect(vswitch('0xabc').flows[0].actions[0].mac_address.to_s).to eq('11:22:33:44:55:66')
          end
        end
      end
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
