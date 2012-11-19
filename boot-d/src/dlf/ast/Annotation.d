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
module dlf.ast.Annotation;

import dlf.ast.Node;
import dlf.ast.Visitor;

//TODO Rename to Attribute?
// TestAttr

/**
* Annotation Base Class
*/
abstract class Attribute : Node
{
	mixin KindMixin!(NodeKind.Attribute);
	
    /// Annotation Name
    string Name;
}

/**
* UnitTest Annotation
*/
final class TestAttribute : Attribute
{
	mixin KindMixin!(NodeKind.TestAttribute);
    mixin VisitorMixin;

    //parameter pre/post methods, depends 
}

/**
* Deprecated Annotation
*/
final class DeprecatedAttribute : Attribute
{
    //mixin(IsKind("DeprecatedAnnotation"));
}

/**
* MainFunction Annotation for declaring a entry points for static/dynamic libraries
*/
final class LibMainAttribute : Attribute
{
    //mixin(IsKind("LibMainAnnotation"));
}
