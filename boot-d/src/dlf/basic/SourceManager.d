/******************************************************************************
*    Dis Programming Language 
*    disc - Bootstrap Dis Compiler
*
*    disc is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    disc is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with disc.  If not, see <http://www.gnu.org/licenses/>.
*
******************************************************************************/
module dlf.basic.SourceManager;

import dlf.basic.Location;
import dlf.basic.Source;

/**
* Manging different sources
*/
public final class SourceManager
{
	/// the sources mapped by id
	private Source sources_[uint];
	
	private uint curId_ = 0;
	
	//Save information for ids
	
	//TODO singleton
	
	///map source names
	
	//Other meta information about file sources?
	
	//get ModificationDate (sourceId)
	
	
	string getName(uint sourceId)
	{
		return "";
	}
	
	Source get(uint id)
	{
		return sources_[id];
	}
	
	Source loadFile(string fileName)
	{
		auto src = new SourceFile(curId_++);
		src.open(fileName);
		return src;
	}
	
	Source loadMemory(string buffer)
	{
		auto src = new SourceString(curId_++, buffer);
		return src;
	}
}
