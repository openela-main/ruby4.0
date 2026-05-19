%ruby_root %{_datadir}/%{name_version}
%ruby_libdir %{ruby_root}/%{name_version}
%ruby_libarchdir %{_libdir}/%{name_version}

%ruby_sitedir site_ruby
%ruby_sitelibdir %{_prefix}/local/share/%{name_version}/%{ruby_sitedir}
%ruby_sitearchdir %{_prefix}/local/%{_lib}/%{name_version}/%{ruby_sitedir}
# For ruby packages we want to filter out any provides caused by private
# libs in %%{ruby_vendorarchdir}/%%{ruby_sitearchdir}.
#
# Note that this must be invoked in the spec file, preferably as
# "%{?ruby_default_filter}", before any %description block.
%ruby_default_filter %{expand: \
%global __provides_exclude_from %{?__provides_exclude_from:%{__provides_exclude_from}|}^(%{ruby_vendorarchdir}|%{ruby_sitearchdir})/.*\\\\.so$ \
}
