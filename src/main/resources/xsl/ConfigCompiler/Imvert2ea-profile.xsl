<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    expand-text="yes"
    version="3.0">
    
    <!-- 
        Create EA profile from the configuration
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:param name="result-type" select="'profile'"/> <!-- profile or toolbox -->
    
    <xsl:output method="xml" encoding="UTF-16" indent="yes"/><!-- bug fix may 1,2020 - Sparx: "I got it to work by changing the encoding in the first line to "UTF-16". I'm not entirely sure why that was necessary."-->
    
    <xsl:variable name="profile-id-string" select="$configuration-metamodel-file/profiles/profile[@lang=$language]/id"/>
    <xsl:variable name="profile-pname-string" select="$configuration-metamodel-file/profiles/profile[@lang=$language]/profile-name"/>
    <xsl:variable name="profile-desc-string" select="$configuration-metamodel-file/profiles/profile[@lang=$language]/desc"/>
    <xsl:variable name="profile-release-string" select="$configuration-metamodel-file/profiles/profile[@lang=$language]/release"/><!-- optional -->
  
    <xsl:variable name="profile-name-string" select="($profile-pname-string,$profile-desc-string)[1]"/>
    
    <xsl:template match="/config">
        <xsl:variable name="metamodel" select="metamodel"/>
        <xsl:variable name="visuals" select="visuals"/>
        <xsl:variable name="tagged-values" select="tagset/tagged-values"/>
        
        <xsl:variable name="profile-id" select="substring(imf:extract(upper-case($profile-id-string),'[A-Z0-9]+'),1,8)"/>
        <xsl:variable name="profile-name" select="$profile-name-string"/>
        <xsl:variable name="profile-version" select="if ($profile-release-string) then concat($profile-release-string,'-',$imvertor-version) else $imvertor-version"/>
        <xsl:variable name="profile-notes" select="imf:insert-fragments-by-index('Generated by Imvertor [1] at [2]',($imvertor-version,imf:format-dateTime(current-dateTime())))"/>
        <xsl:variable name="profile-file-name" select="concat($profile-name-string,'.ea-profile.xml')"/>
        <xsl:variable name="toolbox-file-name" select="concat($profile-name-string,'.ea-toolbox.xml')"/>
        
        <xsl:variable name="measures" select="$visuals/measure"/>
        <xsl:variable name="stereos" select="$visuals/stereo"/>
        <xsl:variable name="categories" select="$visuals/category"/>
        
        <xsl:comment>Enterprise Architect profile/toolbox generated by Imvertor {$imvertor-version} dd. {imf:format-dateTime(current-dateTime())}.</xsl:comment>
        <xsl:comment>This file may be imported into EA and aligns fully with the metamodel named {imf:get-xparm('cli/metamodel')}</xsl:comment>
        
        <xsl:variable name="profile">
            <UMLProfile profiletype="uml2">
                <Documentation id="P{$profile-id}" name="{$profile-name}" version="{$profile-version}" notes="{$profile-notes}"/>
                <Content>
                    <Stereotypes>
                        <xsl:for-each select="$metamodel/stereotypes/stereo[not(@origin='system') and empty(@cross-meta)]/name">
                            <xsl:sort select="."/>
                            
                            <xsl:variable name="name" select="."/> <!-- content is normalized name -->
                            <xsl:variable name="stereo" select=".."/>
                            
                            <xsl:variable name="stereotype-id" select="$stereo/@id"/>
                            
                            <xsl:variable name="visual" select="$stereos[@id = $stereotype-id]/visual"/>
                            
                            <xsl:variable name="backgroundcolor" select="imf:map-measure($measures,$visual/@backgroundcolor,'16777164')"/> <!-- default: blue -->
                            <xsl:variable name="fontcolor" select="imf:map-measure($measures,$visual/@fontcolor,'0')"/>
                            <xsl:variable name="bordercolor" select="imf:map-measure($measures,$visual/@bordercolor,'0')"/>
                            <xsl:variable name="borderwidth" select="imf:map-measure($measures,$visual/@borderwidth,'1')"/>
                            
                            <xsl:comment select="$stereotype-id"/>
                            <Stereotype 
                                name="{$name/@original}" 
                                notes="{$stereo/desc}" 
                                cx="100" cy="80" 
                                bgcolor="{$backgroundcolor}" 
                                fontcolor="{$fontcolor}" 
                                bordercolor="{$bordercolor}" 
                                borderwidth="{$borderwidth}" 
                                hideicon="0">
                                <AppliesTo>
                                    <xsl:for-each select="$stereo/construct">
                                        <Apply type="{imf:get-apply(.)}"/>
                                    </xsl:for-each>
                                </AppliesTo>
                                <TaggedValues>
                                    <xsl:for-each select="$tagged-values/tv[stereotypes/stereo = $name and not(@origin='system')]">
                                        <xsl:sort select="."/>
                                        
                                        <xsl:variable name="tv-id" select="@id"/>
                                        <xsl:variable name="tv-name" select="name/@original"/>
                                        <xsl:variable name="tv-values" select="string-join(declared-values/value/@original,',')"/>
                                        <xsl:variable name="tv-type" select="if (exists(declared-values/value)) then 'enumeration' else ()"/>
                                        <xsl:variable name="tv-note" select="normalize-space(desc)"/>
                                        <xsl:variable name="tv-unit" select="''"/>
                                        
                                        <xsl:variable name="tv-default-enum" select="declared-values/value[@default='yes']/@original"/>
                                        <xsl:variable name="tv-default-set" select="stereotypes/stereo/@default"/>
                                        <xsl:variable name="tv-default" select="($tv-default-set,$tv-default-enum)[1]"/>
                                        
                                        <!-- https://github.com/Imvertor/Imvertor-Maven/issues/141 
                                             Neem de tagged values op als die NIET in de notes field is opgenomen.
                                             Ofwel, alleen als de notes field het niet overneemt van de EA tagged values editor.
                                             
                                             Teruggedraaid; keuze om via notes if via een tv info in te voeren ligt bij de analist.
                                        -->
                                        <xsl:variable name="tv-notes-exists" select="$configuration-notesrules-file/notes-rule/section/@tagged-value = $tv-id"/>
                                        <xsl:variable name="ea-omit-tv-when-notes-field-exists" select="imf:boolean(imf:get-config-parameter('ea-omit-tv-when-notes-field-exists'))"/>
                                        <xsl:choose>
                                            <xsl:when test="not($tv-notes-exists) or not($ea-omit-tv-when-notes-field-exists)">
                                                <Tag name="{$tv-name}" type="{$tv-type}" description="{$tv-note}" unit="{$tv-unit}" values="{$tv-values}" default="{$tv-default}"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:comment>Tagged value already occurs in Notes field: <xsl:value-of select="$tv-name"/></xsl:comment>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </TaggedValues>
                            </Stereotype>
                        </xsl:for-each>        
                    </Stereotypes>
                    <TaggedValueTypes/>
                </Content>
            </UMLProfile>
        </xsl:variable>
        
        <xsl:variable name="toolbox">
            <UMLProfile profiletype="uml2">
                <Documentation id="T{$profile-id}" name="{$profile-name}" version="{$profile-version}" notes="{$profile-notes}"/>
                <Content>
                    <Stereotypes>
                        <xsl:variable name="prefix" select="$metamodel/profiles/profile/id"/>
                        <xsl:for-each-group select="$stereos/toolbox" group-by="@category">
                            <xsl:variable name="category" select="current-grouping-key()"/>
                           
                            <xsl:variable name="name" select="$category"/>
                            <xsl:variable name="alias" select="$categories[@id = $category]/desc"/>
                            <xsl:variable name="notes" select="'Selecteer en klik ergens op het diagram om te plaatsen'"/>
                            <Stereotype name="{$prefix}: {$alias}" alias="{$prefix} {$alias}" notes="{$notes}" cx="0" cy="0" bgcolor="-1" fontcolor="-1" bordercolor="-1" borderwidth="-1" hideicon="0">
                                <AppliesTo>
                                    <Apply type="ToolboxPage"/>
                                </AppliesTo>
                                <TaggedValues>
                                    <xsl:for-each select="for $id in (current-group()/../@id) return $metamodel/stereotypes/stereo[@id = $id]/name">
                                        <xsl:sort select="."/>
                                        <xsl:variable name="name" select="@original"/>
                                        <xsl:variable name="stereo" select=".."/>
                                        <xsl:variable name="stereotype-id" select="$stereo/@id"/>
                                        <xsl:variable name="toolbox" select="$visuals[@id = $stereotype-id]/toolbox"/>
                                        <xsl:variable name="construct-type" select="'UML::' || imf:get-apply($stereo/construct)"/>
                                        <Tag name="{$profile-name}::{$name}({$construct-type})" type="" description="" unit="" values="" default="{$name}"/>
                                    </xsl:for-each>
                                </TaggedValues>
                            </Stereotype>
                        </xsl:for-each-group>
                    </Stereotypes>
                </Content>
            </UMLProfile>
        </xsl:variable>
       
        <xsl:choose>
            <xsl:when test="$result-type = 'toolbox'">
                <MDG.Technology version="1.0">
                    <Documentation id="{$profile-id}" name="{$profile-name}" version="{$profile-version}" notes="{$profile-notes}"/>
                    <UMLProfiles>
                        <xsl:sequence select="$profile"/>
                    </UMLProfiles>
                    <UIToolboxes>
                        <xsl:sequence select="$toolbox"/>
                    </UIToolboxes>
                </MDG.Technology>
                <xsl:sequence select="imf:set-config-string('appinfo','ea-toolbox-file-name',$toolbox-file-name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$profile"/>
                <xsl:sequence select="imf:set-config-string('appinfo','ea-profile-file-name',$profile-file-name)"/>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
   
    <xsl:function name="imf:get-apply">
        <xsl:param name="construct"/>
        <xsl:choose>
            <xsl:when test="$construct = 'attribute'">Attribute</xsl:when>
            <xsl:when test="$construct = 'package'">Package</xsl:when>
            <xsl:when test="$construct = 'class'">Class</xsl:when>
            <xsl:when test="$construct = 'datatype'">DataType</xsl:when>
            <xsl:when test="$construct = 'association'">Association</xsl:when>
            <xsl:when test="$construct = 'enumeration'">Enumeration</xsl:when>
            <xsl:when test="$construct = 'associationend'">AssociationEnd</xsl:when>
            <xsl:when test="$construct = 'associationrole'">AssociationRole</xsl:when>
            <xsl:when test="$construct = 'generalization'">Generalization</xsl:when>
            <xsl:when test="$construct = 'constraint'">Constraint</xsl:when>
            <xsl:when test="$construct = 'primitivetype'">PrimitiveType</xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg($construct,'FATAL','Unknown stereotype appliance: [1]', $construct)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:map-measure" as="xs:string">
        <xsl:param name="measures"/>
        <xsl:param name="id"/>
        <xsl:param name="default"/>
        <xsl:variable name="mapped-value" select="$measures[@id = $id]"/>
        <xsl:choose>
            <xsl:when test="exists($mapped-value)">
                <xsl:value-of select="$mapped-value"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$default"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
