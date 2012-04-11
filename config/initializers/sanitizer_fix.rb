module HTML
	class WhiteListSanitizer
		alias original_sanitize_css sanitize_css
		# use non-greedy mode to match css styles,
		# or in some case, it needs several hours to finish the regex matching
		def sanitize_css(style)
			if style !~ /^(\s*[-\w]+\s*:\s*[^:;]*(;|$)\s*)*?$/
				""
			else
				original_sanitize_css(style)
			end
		end
	end
end
