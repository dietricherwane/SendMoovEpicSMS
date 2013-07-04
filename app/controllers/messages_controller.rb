# -*- encoding : utf-8 -*-
require 'net/http'
require 'cgi'

class MessagesController < ApplicationController

	def deliver
		@message = params
	end
	
	def send_messages
		@text = ''
		@responses_container = ''
		if(params[:to].blank?)
			redirect_to :back, :flash => { :error => "Select a file containing the list of receivers" } 
		else
			@to = params[:to].read.to_s.gsub!(/\s/,'')
			# si le fichier ne contient pas de chiffres ou que le nombre de chiffres n'est pas multiple de 8'
			if(is_not_a_number?(@to) or (@to.length%8 != 0))
				redirect_to :back, :flash => { :error => "Provide a valid phone numbers file" } 
			else
				if(params[:profile] == "Epiq Nation")
					@text = "Pour connaitre toutes tes offres de reductions EPIQ NATION  compose vite le *399*4#."
				else
					@text = "ABONNE SELECT : Decouvrez toutes vos reductions MOOV SELECT en composant *301*2#."
				end
				while (@to.length >= 8)
					request = Typhoeus::Request.new(
						"http://94.247.177.152:15013/cgi-bin/sendsms",
						params: { username: "ngser", password: "ngser", to: @to[0, 8], text: @text, from: params[:profile], smsc: "moovpush", mclass: 0, alt_dcs: 1 },
					)
					hydra = Typhoeus::Hydra.hydra
					hydra.queue(request)
					hydra.run
					response = request.response
					response.code
					response.total_time
					#response.headers_has
					response.body
					@responses_container << @to[0, 8] << "=> " << response.body << "---"
					if(@to.length > 8)
						@to = @to[8, @to.length]
					else
						@to = ''
					end
				end
			end
		end		
	end
	
end
