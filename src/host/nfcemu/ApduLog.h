/**
 * @file   ApduLog.h
 * @author Lukas Schuller
 * @date   Fri Apr 18 17:38:40 2014
 * 
 * @brief  
 * 
 * @license 
 *  Copyright (C) 2014 Lukas Schuller
 * 
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef APDULOG_H
#define APDULOG_H

#include "PacketListener.h"
#include <ostream>
#include <iomanip>
#include <vector>
#include "Util.h"

namespace NfcEmu {

    class ApduLog : public PacketListener {
    
    public:
        ApduLog(std::ostream & os, bool color = false) : mOs(os), mEnableColor(color) {
        }
        virtual bool Notify(Packet const & p) {
            // mOs << "ID: " << std::hex << int(p.Id()) << std::dec
            //     << std::boolalpha << " " << (p.Dir()==Packet::eUp) << std::endl;
            if(p.Id() == UnitId::eCpu) {  // TODO
                if(p.Dir() == Packet::eUp) {
                    mOs << "-->  ";
                } else {
                    mOs << "<--  ";
                }
                mOs << Util::FormatHex(p.Begin(), p.End()) << std::endl;
            }
            return true;
        }

    protected:
        static std::vector<std::string> const debugMsg;

    private:

        std::ostream & mOs;
        bool mEnableColor;


    };

}
#endif /* APDULOG_H */

