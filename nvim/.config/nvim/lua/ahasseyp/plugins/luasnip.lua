return {
	"L3MON4D3/LuaSnip",
	config = function()
		local ls = require("luasnip")

		vim.keymap.set({ "i", "s" }, "<C-d>", function()
			ls.jump(1)
		end, { silent = true })

		local s = ls.snippet
		local t = ls.text_node
		local i = ls.insert_node
		local isn = ls.indent_snippet_node
		local ri = require("luasnip.extras").rep

		ls.add_snippets("python", {
			s("radmin", {
				t("@admin.register("),
				i(1, "Model"),
				t(")"),
				t({ "", "class " }),
				ri(1),
				t("Admin("),
				i(2, "admin.ModelAdmin"),
				t("):"),
				t({ "", "\tlist_display = [" }),
				i(3, "fields"),
				t("]"),
			}),
		})

		ls.add_snippets("python", {
			s("rtype", {
				t("class "),
				i(1, "Model"),
				t("Type(DjangoObjectType):"),
				t({ "", "\t" }),
				t("class Meta:"),
				t({ "", "\t\t" }),
				t("model = "),
				ri(1),
				t({ "", "\t\t" }),
				t("fields = ["),
				i(2, "fields"),
				t("]"),
				t({ "", "\t\t" }),
				t("filter_fields = {"),
				i(3, "filter_fields"),
				t("}"),
				t({ "", "\t\t" }),
				t("interfaces = (relay.Node, )"),
			}),
		})

		ls.add_snippets("python", {
			s("rmodel", {
				t({ "class " }),
				i(1, "Model"),
				t("("),
				i(2, "models.Model"),
				t("):"),
				t({ "", '\t"""' }),
				t({ "", "\t" }),
				i(3, "Docstring"),
				t({ "", '\t"""' }),
				t({ "", "" }),
				t({ "", "\t" }),
				i(4, ""),
				t({ "", "" }),
				t({ "", "\t" }),
				t("class Meta:"),
				t({ "", "\t\t" }),
				t("ordering = ["),
				i(5, ""),
				t("]"),
				t({ "", "" }),
				t({ "", "\t" }),
				t("def __str__(self):"),
				t({ "", "\t\t" }),
				t("return "),
				i(6, ""),
			}),
		})

		ls.add_snippets("python", {
			s("rmserializer", {
				t({ "class " }),
				i(1, "Model"),
				t("Serializer("),
				i(2, "serializers.ModelSerializer"),
				t("):"),
				t({ "", '\t"""' }),
				t({ "", "\t" }),
				i(3, "Docstring"),
				t({ "", '\t"""' }),
				t({ "", "" }),
				t({ "", "\t" }),
				t("class Meta:"),
				t({ "", "\t\t" }),
				t("model = "),
				ri(1),
				t({ "", "\t\t" }),
				t("read_only_fields = ["),
				i(4, ""),
				t("]"),
				t({ "", "\t\t" }),
				t("fields = read_only_fields + ["),
				i(5, ""),
				t("]"),
			}),
		})

		ls.add_snippets("python", {
			s("rmviewset", {
				t({ "class " }),
				i(1, "Panel"),
				i(2, "Model"),
				t("ViewSet("),
				i(3, "GenericViewSet"),
				t("):"),
				t({ "", '\t"""' }),
				t({ "", "\t" }),
				i(4, "Docstring"),
				t({ "", '\t"""' }),
				t({ "", "" }),
				t({ "", "\t" }),
				t("serializer_class = "),
				ri(2),
				t("Serializer"),
			}),
		})

		ls.add_snippets("python", {
			s("mcreate", {
				isn(1, {
					t({ "CreateModelMixin as Create" }),
				}, ""),
			}),
		})

		ls.add_snippets("python", {
			s("mlist", {
				isn(1, {
					t({ "ListModelMixin as List" }),
				}, ""),
			}),
		})

		ls.add_snippets("python", {
			s("mdetail", {
				isn(1, {
					t({ "RetrieveModelMixin as Detail" }),
				}, ""),
			}),
		})

		ls.add_snippets("python", {
			s("mupdate", {
				isn(1, {
					t({ "UpdateModelMixin as Update" }),
				}, ""),
			}),
		})

		ls.add_snippets("python", {
			s("mdelete", {
				isn(1, {
					t({ "DestroyModelMixin as Delete" }),
				}, ""),
			}),
		})

		ls.add_snippets("python", {
			s("rrouter", {
				i(1, "ROUTER"),
				t('.register("'),
				i(2, "url"),
				t('", '),
				i(3, "View"),
				t(', basename="'),
				ri(2),
				t('")'),
			}),
		})

		local clog_snippet = s("clog", {
			isn(1, {
				t({ "console.log('ACA ANDAMOS', '" }),
				ri(1),
				t({ "', " }),
				i(1),
				t({ ");" }),
			}, ""),
		})

		ls.add_snippets(nil, {
			typescriptreact = {
				clog_snippet,
			},
			typescript = {
				clog_snippet,
			},
			javascriptreact = {
				clog_snippet,
			},
			javascript = {
				clog_snippet,
			},
		})
	end,
}
