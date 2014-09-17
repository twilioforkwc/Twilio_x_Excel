module ApplicationHelper
	def logged_in?
		session[:user]
	end

	def current_user
		session[:user]
	end

	def button(name, className, path)
		link_to raw("<button class=\"btn btn-#{className}\">#{name}</button>") , path
	end
	def button_delete(name, path)
		link_to raw("<button class=\"btn btn-danger\">#{name}</button>") , path, method: :delete, data: { confirm: '本当に削除しますか？（取り消し不可）' }
	end
	def button_new(name, path)
		link_to raw("<button class=\"btn btn-primary\">#{name}</button>") , path
	end
end
