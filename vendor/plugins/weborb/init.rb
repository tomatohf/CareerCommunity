# =========================================================================
# init.rb
# Copyright (C) 2006 Midnight Coders, LLC
#
# ruby adaptation, design and implementation: 
#      Harris Reynolds (harris@themidnightcoders.com)
# original design: 
#      Mark Piller (mark@themidnightcoders.com)
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# The software is licensed under the GNU General Public License (GPL)
# For details, see http://www.gnu.org/licenses/gpl.txt.
# =========================================================================

require 'weborb/log'
require 'weborb/config/weborb_config'

if Log.info?
  Log.info( "loading WebORB Configuration" )
end

if ENV['RAILS_ENV'] == 'development'
  # Dependencies.mechanism = :load
  # Modified by Tomato to be compatible with Rails 2.3.4
  ActiveSupport::Dependencies.mechanism = :load
end

WebORBConfig.init