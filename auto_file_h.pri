# This function allow to mimic an auto generated file where the content is replaced with qmake variable values

# $$1 = source file path
# $$2 = target file path
defineTest( autoGenerateFile ) {
	!build_pass {
		generator.source = $${1}
		generator.target = $${2}
		
		win32:!cb_win32 {
			generator.source = $$replace( generator.source, $${Q_SLASH}, $${Q_BACK_SLASH} )
			generator.target = $$replace( generator.target, $${Q_SLASH}, $${Q_BACK_SLASH} )
		}
		
		exists( $${generator.target} ) {
			win32:!cb_win32 {
				system( "del $${generator.target}" )
			} else {
				system( "rm $${generator.target}" )
			}
		}
		
		generator.content = $$cat( $${generator.source}, false )
		#generator.variables = $$find( generator.content, "\\$\\$[^\s\$]+" )
		generator.commands = "grep -E -i -o '\\$\\$[$${Q_OPENING_BRACE}]?[^ $${Q_QUOTE}$]+[$${Q_OPENING_BRACE}]?' $${generator.source}"
		win32:!cb_win32:generator.commands = "echo command not implemented."
		generator.variables = $$system( $${generator.commands} )
		
		#message( cmd: $${cmd} )
		#message( Variables: $$generator.variables )

		for( variable, generator.variables ) {
			name = $${variable}
			name = $$replace( name, $${Q_QUOTE}, "" )
			name = $$replace( name, $${Q_DOLLAR}, "" )
			name = $$replace( name, $${Q_OPENING_BRACE}, "" )
			name = $$replace( name, $${Q_CLOSING_BRACE}, "" )
			
			generator.content = $$replace( generator.content, $${Q_DOLLAR}$${Q_DOLLAR}$${Q_OPENING_BRACE}$${name}$${Q_CLOSING_BRACE}, $$eval( $${name} ) )
			generator.content = $$replace( generator.content, $${Q_DOLLAR}$${Q_DOLLAR}$${name}, $$eval( $${name} ) )
			#message( --- Found: $$variable ($$name) - $$eval( $$name ) )
		}
		
		# escape characters that are special for windows echo command
		win32:!cb_win32 {
			generator.content = $$replace( generator.content, "\\^", "^^" )
			generator.content = $$replace( generator.content, "<", "^<" )
			generator.content = $$replace( generator.content, ">", "^>" )
			generator.content = $$replace( generator.content, "\\|", "^|" )
			generator.content = $$replace( generator.content, "&", "^&" )
			# these should be escaped too but qmake values can't be ( or ) so we can't replace...
			#generator.content = $$replace( generator.content, "\\(", "^(" )
			#generator.content = $$replace( generator.content, "\\)", "^)" )
		} else {
			#mac:generator.content = $$replace( generator.content, $${Q_BACK_SLASH}, $${Q_BACK_SLASH}$${Q_BACK_SLASH}$${Q_BACK_SLASH} )
			#else:generator.content = $$replace( generator.content, $${Q_BACK_SLASH}$${Q_BACK_SLASH}, $${Q_BACK_SLASH}$${Q_BACK_SLASH}$${Q_BACK_SLASH} )
			generator.content = $$replace( generator.content, $${Q_BACK_SLASH}$${Q_BACK_SLASH}, $${Q_BACK_SLASH}$${Q_BACK_SLASH}$${Q_BACK_SLASH} )
			generator.content = $$replace( generator.content, $${Q_QUOTE}, $${Q_BACK_SLASH}$${Q_QUOTE} )
		}
		
		message( Generating $${generator.target}... )
		
		win32:!cb_win32 {
			generator.content = $$replace( generator.content, "\\n", ">> $${generator.target} && echo." )
			generator.commands = "echo ^ $${generator.content} >> $${generator.target}"
		} else {
			generator.commands = "echo \" $${generator.content}\" > $${generator.target}"
		}
		
		system( $${generator.commands} )
		#message( $${generator.content} )
		#message( $${generator.commands} )
	}
}